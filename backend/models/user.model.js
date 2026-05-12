import mongoose from "mongoose"

const userSchema = new mongoose.Schema({
    username: {
        type: String,
        required: true,
        unique: true,
    },
    email: {
        type: String,
        required: true,
        unique: true,
    },
    password: {
        type: String,
        required: true,
    },
    resetPasswordToken: {
        type: String,
    },
    resetPasswordExpires: {
        type: Date,
    },
    otp: {
        type: String,
    },
    otpExpires: {
        type: Date,
    },
    // Profile picture URL (stored in Cloudinary)
    profilePicture: {
        type: String,
        default: '',
    },
},
    { timestamps: true }
)

const User = mongoose.model("User", userSchema)

export default User