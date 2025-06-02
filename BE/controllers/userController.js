import User from "../models/userModel.js";
import jwt from 'jsonwebtoken';

export function caesarEncrypt(text, shift) {
  return text.split('').map(char => {
    if (char.match(/[a-z]/)) {
      return String.fromCharCode(((char.charCodeAt(0) - 97 + shift) % 26) + 97);
    }
    if (char.match(/[A-Z]/)) {
      return String.fromCharCode(((char.charCodeAt(0) - 65 + shift) % 26) + 65);
    }
    return char;
  }).join('');
}

export function caesarDecrypt(text, shift) {
  return caesarEncrypt(text, (26 - (shift % 26)) % 26);
}

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

        // Generate shift secara acak antara 1-26
        const shift = (Math.floor(Math.random() * 1000) % 26) + 1;
        const encrypedPassword = caesarEncrypt(password, shift);
        // Simpan user baru
        await User.create({
            username,
            email,
            password: encrypedPassword,
            shift: shift,
            bb: 0,
            tb: 0,
            usia: 0,
            jenis_kelamin: "Laki-laki"
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
    if (password !== caesarDecrypt(user.password, user.shift)) {
      return res.status(400).json({ status: "Error", msg: "Password salah" });
    }

    // Bikin token
    const accessToken = jwt.sign(
      { userId: user.id, username: user.username },
      process.env.ACCESS_TOKEN_SECRET,
      { expiresIn: "24h" }
    );

    res.cookie("accessToken", accessToken, {
      httpOnly: false,
      secure: false, // Hanya kirim cookie di HTTPS
      sameSite: "None", // Mencegah CSRF
    });

    res.json({
    status:"Sukses",
    accessToken: accessToken,
      msg: "Login berhasil",
      user: {
        userID: user.userID,
        username: user.username,
        bb: user.bb,
        tb: user.tb,
        usia: user.usia,
        jenis_kelamin: user.jenis_kelamin
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
      attributes: ["userID", "username", "email", "bb", "tb", "usia", "jenis_kelamin" ]
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
      attributes: ["userID", "username", "email", "bb", "tb", "usia", "jenis_kelamin" ]
    });
    if (!user) return res.status(404).json({ msg: "User tidak ditemukan" });
    res.json(user);
  } catch (error) {
    res.status(500).json({ msg: error.message });
  }
};

// PUT update user
export const updateUser = async (req, res) => {
  const { username, email, password, bb, tb, usia, jenis_kelamin } = req.body;
  try {
    const user = await User.findByPk(req.params.id);
    if (!user) return res.status(404).json({ msg: "User tidak ditemukan" });

    // Cek apakah email sudah terdaftar
    // const existingEmail = await User.findOne({ where: { email } });
    // if (existingEmail) return res.status(400).json({status: "Error", msg: "Email sudah digunakan" });
        
    // Cek apakah username sudah terdaftar
    const existingUsername = await User.findOne({ where: { username } });
    if (existingUsername) return res.status(400).json({status: "Error", msg: "Username sudah digunakan" });

    const validGender = ["Laki-laki", "Perempuan"];
    if (!validGender.includes(jenis_kelamin)) {
      return res.status(400).json({
        status: "Error",
        msg: "jenis_kelamin harus 'Laki-laki' atau 'Perempuan'"
      });
    }

    user.username = username || user.username;
    user.email = email || user.email;
    user.password = caesarEncrypt(password, user.shift)|| caesarEncrypt(user.password, user.shift);
    user.bb = bb || user.bb;
    user.tb = tb || user.tb;
    user.usia = usia || user.usia;
    user.jenis_kelamin = jenis_kelamin || user.jenis_kelamin;

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