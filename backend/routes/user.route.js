import express from "express"
import { getUsers, signout, updateProfile, updatePassword } from "../controllers/user.controller.js"
import { verifyToken } from "../utils/verifyUser.js"

const router = express.Router()

router.get("/getusers", verifyToken, getUsers)
router.post("/signout", signout)
router.put("/update-profile", verifyToken, updateProfile)
router.put("/update-password", verifyToken, updatePassword)

export default router