/** @type {import('tailwindcss').Config} */
module.exports = {
  content: ["./src/**/*.{html,ts}"],
  theme: {
    extend: {
      fontFamily: {
        sans: ["Poppins", "ui-sans-serif", "system-ui", "sans-serif"],
      },
      colors: {
        kp: {
          bg: "#0D1117",
          surface: "#111827",
          border: "#1F2937",
          primary: "#2563EB",
          accent: "#60A5FA",
          gold: "#FBBF24",
          success: "#4ADE80",
          text: {
            primary: "#F1F5F9",
            secondary: "#9CA3AF",
          },
        },
      },
      borderRadius: {
        card: "16px",
        btn: "8px",
      },
      boxShadow: {
        "glow-primary": "0 0 0 1px rgba(37, 99, 235, 0.35), 0 0 32px rgba(37, 99, 235, 0.18)",
        "glow-accent": "0 0 0 1px rgba(96, 165, 250, 0.35), 0 0 32px rgba(96, 165, 250, 0.14)",
      },
      backgroundImage: {
        "radial-glow": "radial-gradient(closest-side, rgba(37, 99, 235, 0.25), rgba(37, 99, 235, 0))",
      },
    },
  },
  plugins: [],
}

