import User from "../models/user.model.js"
import { errorHandler } from "../utils/error.js"

export const getUsers = async (req, res, next) =>{
    const userId = req.user.id

    const ValidUser = await User.findOne({ _id: userId })
    if (!ValidUser) {
        return next(errorHandler(404, "Unauthorized"))
    }
    const {password: pass, ...rest} = ValidUser._doc

    res.status(200).json(rest)
}

export const signout = async (req, res, next) => {
  try {
    res
      .clearCookie("access_token")
      .status(200)
      .json("User has been loggedout successfully!")
  } catch (error) {
    next(error)
  }
}