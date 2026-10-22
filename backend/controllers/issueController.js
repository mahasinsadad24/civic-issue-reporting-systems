const Issue = require("../models/Issue");
const aiService = require("../services/aiClassificationService");
const storageService = require("../services/storageService");

// @desc    Create a new issue with optional image upload and AI classification
// @route   POST /api/issues
// @access  Private (Authenticated users only)
const createIssue = async (req, res) => {
  try {
    const { description, speechText, category, lat, lng } = req.body;

    // Determine submission method
    let submissionMethod = "text";
    if (speechText && description) {
      submissionMethod = "mixed";
    } else if (speechText) {
      submissionMethod = "speech";
    }

    // Use speechText as primary description if available
    const finalDescription = speechText || description;

    // Basic validation
    if (!finalDescription || !lat || !lng) {
      return res.status(400).json({
        success: false,
        message: "Please provide description (or speechText), latitude, and longitude"
      });
    }

    // Intelligent Hinting Logic (Shared for Sync and Async AI)
    let hint = category;
    if (!hint || hint === 'other') {
      const desc = (finalDescription || "").toLowerCase();
      if (desc.includes('garbage') || desc.includes('trash') || desc.includes('waste') || desc.includes('dump')) hint = 'garbage';
      else if (desc.includes('pothole') || desc.includes('road') || desc.includes('asphalt')) hint = 'pothole';
      else if (desc.includes('light') || desc.includes('lamp') || desc.includes('dark') || desc.includes('street')) hint = 'streetlight';
      else if (desc.includes('water') || desc.includes('leak') || desc.includes('pipe') || desc.includes('sewer')) hint = 'water';
      else if (desc.includes('traffic') || desc.includes('jam') || desc.includes('signal') || desc.includes('accident')) hint = 'traffic';
      else hint = "unknown";
    }

    // Handle uploaded image
    let imageUrl = null;
    let aiCategory = "unknown";
    let aiConfidence = 0;

    if (req.file) {
      try {
        console.log("Uploading image to MinIO...");
        // Upload to MinIO and get OBJECT KEY (not URL)
        const objectKey = await storageService.uploadFile(req.file);
        console.log("Image uploaded, key:", objectKey);

        // Construct PROXY URL
        imageUrl = `/api/media/${objectKey}`;

        // Optimize: You might want to pass the URL or file path to AI service
        // For now, retaining placeholder AI call or if we had a real one
        // await aiService.classifyImage(req.file.path); 

        // Use the smart hint calculated at the start of the function

        const aiResult = await aiService.classifyImage(req.file.path, hint);
        aiCategory = aiResult.category;
        aiConfidence = aiResult.confidence;

      } catch (error) {
        console.error("File upload or AI failed:", error);
        // We do typically fail if upload fails, but if AI fails we might continue
        if (error.message.includes("Storage")) {
          return res.status(500).json({ success: false, message: "Failed to upload image" });
        }
      }
    }

    // Create issue document
    const issueData = {
      description: finalDescription,
      submissionMethod,
      location: {
        type: "Point",
        coordinates: [parseFloat(lng), parseFloat(lat)]
      },
      imageUrl, // This is now the MinIO URL
      aiCategory,
      aiConfidence,
      createdBy: req.user._id  // Real user from DB
    };

    // Add optional fields
    if (speechText) issueData.speechText = speechText;
    if (category) issueData.category = category;

    const issue = new Issue(issueData);
    const savedIssue = await issue.save();

    // Populate user information for response
    await savedIssue.populate("createdBy", "name email");

    // 🤖 AUTO-TRIGGER AI ANALYSIS (Fire and Forget)
    // 🤖 AUTO-TRIGGER AI ANALYSIS (Fire and Forget)
    // "from the database the image should be accesed by the model... and sends to the database"
    if (req.file && req.file.path) {
      // Pass the LOCAL FILE PATH to the AI service (since it runs on the same machine)
      // Pass 'hint' calculated at the start of the function

      aiService.classifyImage(req.file.path, hint).then(async (aiResult) => {
        console.log(`[Auto-AI] Analyzing Issue ${savedIssue._id}...`);

        // Re-fetch issue to ensure we don't overwrite concurrent updates
        const issueToUpdate = await Issue.findById(savedIssue._id);
        if (issueToUpdate) {
          issueToUpdate.aiCategory = aiResult.category || "unknown";
          issueToUpdate.aiConfidence = aiResult.confidence || 0;
          await issueToUpdate.save();
          console.log(`[Auto-AI] Issue ${savedIssue._id} updated with category: ${issueToUpdate.aiCategory}`);
        }
      }).catch(err => {
        console.error(`[Auto-AI] Failed for Issue ${savedIssue._id}:`, err.message);
      });
    }

    res.status(201).json({
      success: true,
      message: "Issue created successfully",
      data: {
        ...savedIssue.toJSON(),
        // Note: AI fields might be 'unknown' in this immediate response 
        // because analysis runs in background. Frontend should poll or listen for updates.
        aiClassification: {
          category: aiCategory, // Placeholder prompt value
          confidence: aiConfidence,
          hasImage: !!imageUrl
        }
      }
    });

  } catch (error) {
    console.error("Error creating issue:", error);
    res.status(500).json({
      success: false,
      message: "Server error while creating issue",
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
};

// @desc    Get all issues
// @route   GET /api/issues
// @access  Public (but shows different info based on auth)
const getIssues = async (req, res) => {
  try {
    const { category, status, hasImage, limit = 50, page = 1, myIssues } = req.query;

    // Build filter object
    const filter = {};
    if (category) filter.category = category;
    if (status) filter.status = status;
    if (hasImage === 'true') filter.imageUrl = { $ne: null };
    if (hasImage === 'false') filter.imageUrl = null;

    // Filter to show only user's issues if requested and authenticated
    if (myIssues === 'true' && req.user) {
      filter.createdBy = req.user._id;
    }

    // Calculate pagination
    const skip = (page - 1) * limit;

    let query = Issue.find(filter)
      .sort({ createdAt: -1 })
      .limit(parseInt(limit))
      .skip(skip);

    // Populate user info if user is authenticated
    // Note: If users are not fully set up in DB loop yet, verify
    // But requirement says "Mongodb Connection... establish clean...".
    query = query.populate("createdBy", "name");

    const issues = await query;

    // Get total count for pagination
    const totalCount = await Issue.countDocuments(filter);

    res.status(200).json({
      success: true,
      count: issues.length,
      totalCount,
      currentPage: parseInt(page),
      totalPages: Math.ceil(totalCount / limit),
      data: issues.map(issue => ({
        ...issue.toJSON(),
        hasAIClassification: issue.aiCategory !== 'unknown' && issue.aiConfidence > 0,
        // Hide sensitive info for non-owners (Project requirement: "ensure frontend/app only talk to backend APIs" -> clean responses)
        createdBy: issue.createdBy ? { name: issue.createdBy.name } : { name: "Anonymous" }
      }))
    });

  } catch (error) {
    console.error("Error fetching issues:", error);
    res.status(500).json({
      success: false,
      message: "Server error while fetching issues"
    });
  }
};

// @desc    Get issue by ID
// @route   GET /api/issues/:id
// @access  Public
const getIssueById = async (req, res) => {
  try {
    const issue = await Issue.findById(req.params.id).populate("createdBy", "name");

    if (!issue) {
      return res.status(404).json({
        success: false,
        message: "Issue not found"
      });
    }

    res.status(200).json({
      success: true,
      data: {
        ...issue.toJSON(),
        hasAIClassification: issue.aiCategory !== 'unknown' && issue.aiConfidence > 0
      }
    });

  } catch (error) {
    console.error("Error fetching issue:", error);
    res.status(500).json({
      success: false,
      message: "Server error while fetching issue"
    });
  }
};

// @desc    Get AI service status
// @route   GET /api/issues/ai/status
// @access  Public
const getAIServiceStatus = async (req, res) => {
  try {
    const isAvailable = await aiService.isServiceAvailable();
    const serviceInfo = await aiService.getServiceInfo();

    res.status(200).json({
      success: true,
      aiService: {
        available: isAvailable,
        ...serviceInfo
      }
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Error checking AI service status"
    });
  }
};

module.exports = {
  createIssue,
  getIssues,
  getIssueById,
  getAIServiceStatus
};