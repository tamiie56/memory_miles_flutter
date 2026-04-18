import express from "express"
import { verifyToken } from "../utils/verifyUser.js"
import { addTravelStory, deleteImage, deleteTravelStory, editTravelStory, filterTravelStories, getAllTravelStory, imageUpload, searchTravelStory, updateIsFavorite } from "../controllers/travelStory.controller.js"
import upload from "../multer.js"

const router = express.Router()

router.post("/image-upload", (req, res, next) => {
    upload.single("image")(req, res, (err) => {
        if (err) {
            console.error("Multer error:", err)
            return res.status(500).json({ message: err.message })
        }
        next()
    })
}, imageUpload)

router.delete("/delete-image", deleteImage)

router.post("/add", verifyToken, addTravelStory)

router.get("/get-all", verifyToken, getAllTravelStory)

router.post("/edit-story/:id", verifyToken, editTravelStory)

router.delete("/delete-story/:id", verifyToken, deleteTravelStory)

router.put("/update-is-favorite/:id", verifyToken, updateIsFavorite)

router.get("/search", verifyToken, searchTravelStory)

router.get("/filter", verifyToken, filterTravelStories)

export default router