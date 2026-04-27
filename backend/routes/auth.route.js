import express from "express"
import { signin, signup, forgotPassword, resetPassword } from "../controllers/auth.controller.js"

const router = express.Router()

router.post("/signup", signup)
router.post("/signin", signin)
router.post("/forgot-password", forgotPassword)  // ✅ নতুন
router.post("/reset-password", resetPassword)    // ✅ নতুন

export default router