import mongoose from "mongoose"

const travelStorySchema = new mongoose.Schema({
   title: {
    type: String,
    required: true,
   },
   
   story: {
    type: String,
    required: true,
   },

   visitedLocation: {
    type: [String],
    default: [],
   },

   isFavorite: {
    type: Boolean,
    default: false,
   },

   userId: {
    type: mongoose.Schema.Types.ObjectId,
    ref: "User",
    required: true,
   },

   // image এবং video দুইটাই এখানে থাকবে
   mediaUrls: {
    type: [String],
    default: [],
   },

   visitedDate: {
    type: Date,
    required: true,
   },
}, 
{ timestamps: true }
)
 
const TravelStory = mongoose.model("TravelStory", travelStorySchema)

export default TravelStory