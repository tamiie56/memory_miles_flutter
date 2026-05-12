import bcryptjs from "bcryptjs"
import User from "../models/user.model.js"
import { errorHandler } from "../utils/error.js"
import cloudinary from "cloudinary"

cloudinary.v2.config({
    cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
    api_key: process.env.CLOUDINARY_API_KEY,
    api_secret: process.env.CLOUDINARY_API_SECRET,
})

export const getUsers = async (req, res, next) => {
    const userId = req.user.id

    const validUser = await User.findOne({ _id: userId })
    if (!validUser) {
        return next(errorHandler(404, "Unauthorized"))
    }
    const { password: pass, ...rest } = validUser._doc

    res.status(200).json(rest)
}

export const signout = async (req, res, next) => {
    try {
        res
            .clearCookie("access_token")
            .status(200)
            .json("User has been logged out successfully!")
    } catch (error) {
        next(error)
    }
}

export const updateProfile = async (req, res, next) => {
    const userId = req.user.id
    const { username, email } = req.body

    try {
        const user = await User.findById(userId)
        if (!user) {
            return next(errorHandler(404, "User not found"))
        }

        if (username) user.username = username
        if (email) user.email = email

        await user.save()

        const { password: pass, ...rest } = user._doc
        res.status(200).json(rest)

    } catch (error) {
        next(error)
    }
}

export const updatePassword = async (req, res, next) => {
    const userId = req.user.id
    const { oldPassword, newPassword } = req.body

    if (!oldPassword || !newPassword) {
        return next(errorHandler(400, "All fields are required"))
    }

    try {
        const user = await User.findById(userId)
        if (!user) {
            return next(errorHandler(404, "User not found"))
        }

        const isValid = bcryptjs.compareSync(oldPassword, user.password)
        if (!isValid) {
            return next(errorHandler(400, "Current password is incorrect"))
        }

        user.password = bcryptjs.hashSync(newPassword, 10)
        await user.save()

        res.status(200).json({ message: "Password updated successfully" })

    } catch (error) {
        next(error)
    }
}

export const updateProfilePicture = async (req, res, next) => {
    const userId = req.user.id

    try {
        if (!req.file) {
            return next(errorHandler(400, "No image provided"))
        }

        // Upload to Cloudinary
        const result = await new Promise((resolve, reject) => {
            const stream = cloudinary.v2.uploader.upload_stream(
                {
                    folder: "memory_miles/profiles",
                    transformation: [
                        { width: 200, height: 200, crop: "fill", gravity: "face" }
                    ]
                },
                (error, result) => {
                    if (error) reject(error)
                    else resolve(result)
                }
            )
            stream.end(req.file.buffer)
        })

        const user = await User.findById(userId)
        if (!user) {
            return next(errorHandler(404, "User not found"))
        }

        user.profilePicture = result.secure_url
        await user.save()

        const { password: pass, ...rest } = user._doc
        res.status(200).json(rest)

    } catch (error) {
        next(error)
    }
}