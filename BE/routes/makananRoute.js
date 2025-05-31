import express from "express";
import {
  getAllMakanan,
  getMakananByUserAndDate,
  createMakanan,
  updateMakanan,
  deleteMakanan,
} from "../controllers/makananController.js";
import verifyToken from "../middleware/verifyToken.js";

const router = express.Router();

router.get("/makanan", verifyToken, getAllMakanan)

router.get("/makanan/:userID", verifyToken, getMakananByUserAndDate)

router.post("/makanan", verifyToken, createMakanan)

router.put("/makanan/:id", verifyToken, updateMakanan)

router.delete("/makanan/:id", verifyToken, deleteMakanan)

export default router;