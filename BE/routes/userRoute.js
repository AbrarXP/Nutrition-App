import express from "express";
import {
  getUsers,
  getUserById,
  updateUser,
  deleteUser,
  Login,
  Register
} from "../controllers/userController.js";
import verifyToken from "../middleware/verifyToken.js";

const router = express.Router();

// Login
router.post("/login", Login);

// Create User
router.post("/register", Register);

// Read user
router.get("/users", verifyToken, getUsers);

// Read user by ID
router.get("/users/:id", verifyToken, getUserById);

// Update user
router.put("/users/:id", verifyToken, updateUser);

// Delete user
router.delete("/users/:id", verifyToken, deleteUser);

export default router;