const express = require("express");
const os = require("os");

const app = express();
const PORT = 3000;

// middleware
app.use(express.json());

// simple logger
app.use((req, res, next) => {
  console.log(`${req.method} ${req.url}`);
  next();
});

// root endpoint
app.get("/", (req, res) => {
  res.send("Concert Ticketing Backend API 🎫");
});

// health check
app.get("/api/health", (req, res) => {
  res.status(200).json({
    success: true,
    message: "Service is healthy",
    hostname: os.hostname(),
    uptime: process.uptime(),
    timestamp: new Date()
  });
});

// tickets endpoint
app.get("/api/tickets", (req, res) => {
  try {
    const tickets = [
      { id: 1, name: "Coldplay Concert", price: 1500000 },
      { id: 2, name: "Taylor Swift Tour", price: 2500000 },
      { id: 3, name: "Bruno Mars Live", price: 1800000 }
    ];

    res.status(200).json({
      success: true,
      count: tickets.length,
      data: tickets
    });
  } catch (error) {
    res.status(500).json({
      success: false,
      message: "Failed to fetch tickets"
    });
  }
});

// 404 handler
app.use((req, res) => {
  res.status(404).json({
    success: false,
    message: "Route not found"
  });
});

// global error handler
app.use((err, req, res, next) => {
  console.error(err.stack);
  res.status(500).json({
    success: false,
    message: "Internal server error"
  });
});

// start server
app.listen(PORT, "0.0.0.0", () => {
  console.log(`Backend running on port ${PORT}`);
});