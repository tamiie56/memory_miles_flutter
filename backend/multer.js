import { v2 as cloudinary } from "cloudinary"
import { CloudinaryStorage } from "multer-storage-cloudinary"
import multer from "multer"
import dotenv from "dotenv"

dotenv.config()

cloudinary.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET,
})

const storage = new CloudinaryStorage({
    cloudinary: cloudinary,
    params: async (req, file) => {
        const isVideo = file.mimetype.startsWith("video/")
        return {
            folder: "memory_miles",
            resource_type: isVideo ? "video" : "image",
            allowed_formats: ["jpg", "jpeg", "png", "gif", "webp", "mp4", "mov", "avi"],
        }
    },
})

const fileFilter = (req, file, cb) => {
    const allowedMimes = [
        "image/jpeg", "image/png", "image/gif", "image/webp",
        "video/mp4", "video/quicktime", "video/avi",
        "application/octet-stream"
    ]
    const allowedExtensions = /\.(jpg|jpeg|png|gif|webp|mp4|mov|avi)$/i

    if (
        file.mimetype.startsWith("image/") ||
        file.mimetype.startsWith("video/") ||
        allowedMimes.includes(file.mimetype) ||
        allowedExtensions.test(file.originalname)
    ) {
        cb(null, true)
    } else {
        cb(new Error("Only image and video files are allowed"), false)
    }
}

const upload = multer({ storage, fileFilter })

export default upload