import multer from "multer";
import path from "path"

// storage configuration
const storage = multer.diskStorage({
    destination: function(req, file, cb){
        cb(null, "./uploads/")
    },
    filename: function(req, file, cb){
       cb(null, Date.now() + path.extname(file.originalname))
    },
})

// file filter - Flutter Web থেকে আসা file accept করার জন্য
const fileFilter = (req, file, cb) => {
    const allowedExtensions = /\.(jpg|jpeg|png|gif|webp|bmp)$/i

    if (file.mimetype.startsWith("image/") ||
        file.mimetype === "application/octet-stream" ||
        allowedExtensions.test(file.originalname)) {
        cb(null, true)
    } else {
        cb(new Error("Only image files are allowed"), false)
    }
}

// initialize multer instance
const upload = multer({storage, fileFilter})

export default upload