import express from "express";
import cors from "cors";
import db from './config/database.js';
import cookieParser from 'cookie-parser';

import userRoutes from "./routes/userRoute.js";

import dotenv from "dotenv";
dotenv.config();

const app = express(); // <<< INI WAJIB ADA
app.use(cookieParser());

// Middleware
app.use(cors({
    origin: "http://localhost", // ganti sesuai frontend kamu
    credentials: true
}));
app.use(express.json());

// Routes
app.use("/api", userRoutes);

// Sync DB dan mulai server
db.sync().then(() => console.log("Database synced"));

app.listen(5000, () => console.log("Server running on port 5000"));
