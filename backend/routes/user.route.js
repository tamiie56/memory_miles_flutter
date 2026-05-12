import express from "express"
import multer from "multer"
import { getUsers, signout, updateProfile, updatePassword, updateProfilePicture } from "../controllers/user.controller.js"
import { verifyToken } from "../utils/verifyUser.js"

const storage = multer.memoryStorage()
const upload = multer({
    storage,
    limits: { fileSize: 5 * 1024 * 1024 },
    fileFilter: (req, file, cb) => {
        if (file.mimetype.startsWith("image/")) cb(null, true)
        else cb(new Error("Only images allowed"))
    }
})

const router = express.Router()

router.get("/getusers", verifyToken, getUsers)
router.post("/signout", signout)
router.put("/update-profile", verifyToken, updateProfile)
router.put("/update-password", verifyToken, updatePassword)
router.post("/update-profile-picture", verifyToken, upload.single("profilePicture"), updateProfilePicture)

export default router