import TravelStory from "../models/travelStory.model.js"
import { errorHandler } from "../utils/error.js"

export const addTravelStory = async (req, res, next) => {
    const { title, story, visitedLocation, isFavorite, mediaUrls, visitedDate } = req.body
    const userId = req.user.id

    if (!title || !story || !visitedLocation || !visitedDate) {
        return next(errorHandler(400, "All fields are required"))
    }

    const parsedVisitedDate = new Date(parseInt(visitedDate))

    let parsedMediaUrls = []
    if (mediaUrls) {
        parsedMediaUrls = typeof mediaUrls === 'string' ? JSON.parse(mediaUrls) : mediaUrls
    }

    try {
        const travelStory = new TravelStory({
            title,
            story,
            visitedLocation,
            userId,
            mediaUrls: parsedMediaUrls,
            visitedDate: parsedVisitedDate,
        })
        await travelStory.save()
        res.status(201).json({
            story: travelStory,
            message: "Travel story added successfully"
        })
    } catch (error) {
        next(error)
    }
}

export const getAllTravelStory = async (req, res, next) => {
    const userId = req.user.id
    try {
        const travelStories = await TravelStory.find({ userId: userId }).sort({ isFavorite: -1 })
        res.status(200).json({ stories: travelStories })
    } catch (error) {
        next(error)
    }
}

export const imageUpload = async (req, res, next) => {
    try {
        if (!req.files || req.files.length === 0) {
            return next(errorHandler(400, "No files uploaded"))
        }
        const urls = req.files.map(file => file.path)
        res.status(201).json({ mediaUrls: urls })
    } catch (error) {
        next(error)
    }
}

export const deleteImage = async (req, res, next) => {
    res.status(200).json({ message: "Media deleted successfully" })
}

export const editTravelStory = async (req, res, next) => {
    const { id } = req.params
    const { title, story, visitedLocation, mediaUrls, visitedDate } = req.body
    const userId = req.user.id

    if (!title || !story || !visitedLocation || !visitedDate) {
        return next(errorHandler(400, "All fields are required"))
    }

    const parsedVisitedDate = new Date(parseInt(visitedDate))

    let parsedMediaUrls = []
    if (mediaUrls) {
        parsedMediaUrls = typeof mediaUrls === 'string' ? JSON.parse(mediaUrls) : mediaUrls
    }

    try {
        const travelStory = await TravelStory.findOne({ _id: id, userId: userId })
        if (!travelStory) {
            return next(errorHandler(404, "Travel story not found"))
        }

        travelStory.title = title
        travelStory.story = story
        travelStory.visitedLocation = visitedLocation
        travelStory.mediaUrls = parsedMediaUrls
        travelStory.visitedDate = parsedVisitedDate

        await travelStory.save()
        res.status(200).json({
            story: travelStory,
            message: "Travel story updated successfully"
        })
    } catch (error) {
        next(error)
    }
}

export const deleteTravelStory = async (req, res, next) => {
    const { id } = req.params
    const userId = req.user.id
    try {
        const travelStory = await TravelStory.findOne({ _id: id, userId: userId })
        if (!travelStory) {
            return next(errorHandler(404, "Travel story not found"))
        }
        await TravelStory.deleteOne({ _id: id, userId: userId })
        res.status(200).json({ message: "Travel story deleted successfully" })
    } catch (error) {
        next(error)
    }
}

export const updateIsFavorite = async (req, res, next) => {
    const { id } = req.params
    const { isFavorite } = req.body
    const userId = req.user.id
    try {
        const travelStory = await TravelStory.findOne({ _id: id, userId: userId })
        if (!travelStory) {
            return next(errorHandler(404, "Travel story not found"))
        }
        travelStory.isFavorite = isFavorite
        await travelStory.save()
        res.status(200).json({ story: travelStory, message: "Update successful" })
    } catch (error) {
        next(error)
    }
}

export const searchTravelStory = async (req, res, next) => {
    const { query } = req.query
    const userId = req.user.id
    if (!query) {
        return next(errorHandler(404, "Search query is required"))
    }
    try {
        const travelStories = await TravelStory.find({
            userId: userId,
            $or: [
                { title: { $regex: query, $options: "i" } },
                { story: { $regex: query, $options: "i" } },
                { visitedLocation: { $regex: query, $options: "i" } }
            ]
        }).sort({ isFavorite: -1 })
        res.status(200).json({ stories: travelStories })
    } catch (error) {
        next(error)
    }
}

export const filterTravelStories = async (req, res, next) => {
    const { startDate, endDate } = req.query
    const userId = req.user.id
    try {
        const start = new Date(parseInt(startDate))
        const end = new Date(parseInt(endDate))
        const filteredStories = await TravelStory.find({
            userId: userId,
            visitedDate: { $gte: start, $lte: end }
        }).sort({ isFavorite: -1 })
        res.status(200).json({ stories: filteredStories })
    } catch (error) {
        next(error)
    }
}