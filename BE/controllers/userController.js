import User from "../models/userModel.js";
import jwt from 'jsonwebtoken';

// Create user
export const Register = async(req, res) => {
    const { username, email, password } = req.body;

    try{

        // Cek apakah email sudah terdaftar
        const existingEmail = await User.findOne({ where: { email } });
        if (existingEmail) return res.status(400).json({status: "Error", msg: "Email sudah digunakan" });

        // Cek apakah username sudah terdaftar
        const existingUsername = await User.findOne({ where: { username } });
        if (existingUsername) return res.status(400).json({status: "Error", msg: "Username sudah digunakan" });

        // Simpan user baru
        await User.create({
            username,
            email,
            password,
        });

        res.status(201).json({status: "Sukses", msg: "Registrasi berhasil" });
    }catch(error){
        res.status(500).json({ msg: error.message });
    }
}

export const Login = async(req, res) => {
const { username, password } = req.body;
  try {

    // Cek usernya ada ga
    const user = await User.findOne({ where: { username } });
    if (!user) return res.status(404).json({status: "Error", msg: "User tidak ditemukan" });

     // Bandingkan password langsung
    if (password !== user.password) {
      return res.status(400).json({ status: "Error", msg: "Password salah" });
    }

    // Bikin token
    const accessToken = jwt.sign(
      { userId: user.id, username: user.username },
      process.env.ACCESS_TOKEN_SECRET,
      { expiresIn: "5m" }
    );

    const refreshToken = jwt.sign(
      { userId: user.id },
      process.env.REFRESH_TOKEN_SECRET,
      { expiresIn: "1h" }
    );

    // Kirim via cookie
    res.cookie("accessToken", accessToken, {
        httpOnly: false,
        secure: false,
        sameSite: "None", 
        maxAge: 5 * 60 * 1000 // 15 menit
    });

    res.cookie("refreshToken", refreshToken, {
        httpOnly: false,
        secure: false,
        sameSite: "None",
        maxAge: 60 * 60 * 1000 //1 jam 
    });

    res.json({
    status:"Sukses",
    accessToken: accessToken,
      msg: "Login berhasil",
      user: {
        id: user.id,
        username: user.username,
      }
    });

  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
}

// GET semua user
export const getUsers = async (req, res) => {
  try {
    const users = await User.findAll({
      attributes: ["userID", "username", "email"]
    });
    res.json(users);
  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
};

// GET user by ID
export const getUserById = async (req, res) => {
  try {
    const user = await User.findByPk(req.params.id, {
      attributes: ["userID", "username", "email"]
    });
    if (!user) return res.status(404).json({ msg: "User tidak ditemukan" });
    res.json(user);
  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
};

// PUT update user
export const updateUser = async (req, res) => {
  const { username, email, password } = req.body;
  try {
    const user = await User.findByPk(req.params.id);
    if (!user) return res.status(404).json({ msg: "User tidak ditemukan" });

    // Cek apakah email sudah terdaftar
    const existingEmail = await User.findOne({ where: { email } });
    if (existingEmail) return res.status(400).json({status: "Error", msg: "Email sudah digunakan" });
        
    // Cek apakah username sudah terdaftar
    const existingUsername = await User.findOne({ where: { username } });
    if (existingUsername) return res.status(400).json({status: "Error", msg: "Username sudah digunakan" });


    user.username = username || user.username;
    user.email = email || user.email;
    user.password = password || user.password;

    await user.save();
    res.json({ msg: "User berhasil diupdate", user });
  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
};

// DELETE user
export const deleteUser = async (req, res) => {
  try {
    const user = await User.findByPk(req.params.id);
    if (!user) return res.status(404).json({ msg: "User tidak ditemukan" });

    await user.destroy();
    res.json({ msg: "User berhasil dihapus" });
  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
};