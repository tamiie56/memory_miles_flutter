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
        const isVideo = file.mimetype.startsWith("video/") ||
            file.originalname.match(/\.(mp4|mov|avi|mkv)$/i)

        return {
            folder: "memory_miles",
            resource_type: isVideo ? "video" : "image",
            allowed_formats: isVideo
                ? ["mp4", "mov", "avi", "mkv"]
                : ["jpg", "jpeg", "png", "gif", "webp"],
        }
    },
})

const fileFilter = (req, file, cb) => {
    const isImage = file.mimetype.startsWith("image/")
    const isVideo = file.mimetype.startsWith("video/")
    const isOctet = file.mimetype === "application/octet-stream"
    const hasVideoExt = /\.(mp4|mov|avi|mkv)$/i.test(file.originalname)
    const hasImageExt = /\.(jpg|jpeg|png|gif|webp)$/i.test(file.originalname)

    if (isImage || isVideo || (isOctet && (hasVideoExt || hasImageExt))) {
        cb(null, true)
    } else {
        cb(new Error("Only image and video files are allowed"), false)
    }
}

const upload = multer({ storage, fileFilter })

export default upload