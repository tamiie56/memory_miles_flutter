import bcryptjs from "bcryptjs"
import crypto from "crypto"
import User from "../models/user.model.js"
import { errorHandler } from "../utils/error.js"
import jwt from "jsonwebtoken"
import sendEmail from "../utils/sendEmail.js"

export const signup = async (req, res, next) => {
    const { username, email, password } = req.body

    if (!username || !email || !password || username === "" || email === "" || password === "") {
        return next(errorHandler(400, "All fields are required"))
    }

    const existingUser = await User.findOne({ email })
    if (existingUser) {
        return next(errorHandler(409, "User already exist with this email!"))
    }

    const hashedPassword = bcryptjs.hashSync(password, 10)
    const newUser = new User({ username, email, password: hashedPassword })

    try {
        await newUser.save()
        res.json("Signup successful")
    } catch (error) {
        next(error)
    }
}

export const signin = async (req, res, next) => {
    const { email, password } = req.body

    if (!email || !password || email === "" || password === "") {
        return next(errorHandler(400, "All fields are required"))
    }

    try {
        const validUser = await User.findOne({ email })
        if (!validUser) {
            return next(errorHandler(404, "User not found"))
        }

        const validPassword = bcryptjs.compareSync(password, validUser.password)
        if (!validPassword) {
            return next(errorHandler(400, "Wrong Credentials"))
        }

        const token = jwt.sign({ id: validUser._id }, process.env.JWT_SECRET)
        const { password: pass, ...rest } = validUser._doc

        res.status(200)
            .cookie("access_token", token, { httpOnly: true })
            .json({ ...rest, token })

    } catch (error) {
        next(error)
    }
}

export const forgotPassword = async (req, res, next) => {
    const { email } = req.body

    if (!email || email === "") {
        return next(errorHandler(400, "Email is required"))
    }

    try {
        const user = await User.findOne({ email })

        if (!user) {
            return next(errorHandler(404, "No account found with this email"))
        }

        const token = crypto.randomBytes(32).toString("hex")

        user.resetPasswordToken = token
        user.resetPasswordExpires = Date.now() + 60 * 60 * 1000
        await user.save()

        const resetUrl = `${process.env.CLIENT_URL}/reset-password?token=${token}&email=${email}`

        await sendEmail({
            to: user.email,
            subject: "Memory Miles - Password Reset",
            html: `
                <h2>Password Reset Request</h2>
                <p>Click the button below to reset your password. This link expires in <strong>1 hour</strong>.</p>
                <a href="${resetUrl}" style="
                    display:inline-block;
                    padding:12px 24px;
                    background:#4f46e5;
                    color:#fff;
                    border-radius:8px;
                    text-decoration:none;
                    font-weight:bold;
                ">Reset Password</a>
                <p>If you did not request this, please ignore this email.</p>
            `,
        })

        res.status(200).json({ message: "Reset email sent successfully" })

    } catch (error) {
        next(error)
    }
}

export const resetPassword = async (req, res, next) => {
    const { email, token, newPassword } = req.body

    if (!email || !token || !newPassword) {
        return next(errorHandler(400, "All fields are required"))
    }

    try {
        const user = await User.findOne({
            email,
            resetPasswordToken: token,
            resetPasswordExpires: { $gt: Date.now() },
        })

        if (!user) {
            return next(errorHandler(400, "Token is invalid or has expired"))
        }

        user.password = bcryptjs.hashSync(newPassword, 10)
        user.resetPasswordToken = undefined
        user.resetPasswordExpires = undefined

        await user.save()

        res.status(200).json({ message: "Password reset successful. You can now log in." })

    } catch (error) {
        next(error)
    }
}