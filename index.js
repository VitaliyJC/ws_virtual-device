// virtual_device.js
import WebSocket from "ws";
import axios from "axios";

const token = process.argv[2]; // Токен передаётся как аргумент

let isRunning = true;
let intervalId = null;

if (!token) {
  console.error("❌ Не передан токен. Использование: node virtual_device.js <token>");
  process.exit(1);
}

const WS_URL = `ws://ws_nginx/ws_socket?type=device&token=${token}`;
const API_URL = `http://ws_nginx/ws_api/telemetry`;

let deviceId = null;

const ws = new WebSocket(WS_URL);

ws.on("open", () => {
  console.log("✅ Виртуальное устройство подключилось по WebSocket");

  console.log("token ", token);
});

ws.on("message", (msg) => {
  const data = JSON.parse(msg);
  // console.log("data :", data);

  if (data.type === "welcome") {
    deviceId = data.deviceId;

    console.log("📡 Получен deviceId:", deviceId);

    if (!deviceId) {
      console.error("❌ Нет устройств для этого токена");
      process.exit(1);
    }

    // Каждую секунду шлём телеметрию
    intervalId = setInterval(async () => {
      if (!isRunning) return;
      const voltage = (3.0 + Math.random()).toFixed(2);
      const temperature = (20 + Math.random() * 10).toFixed(1);

      try {
        await axios.post(API_URL, {
          device_id: deviceId,
          voltage,
          temperature,
        });

        console.log(`📤 Отправлено: ${voltage} В, ${temperature} °C`);
      } catch (err) {
        const status = err?.response?.status;
        const msg = err?.response?.data?.message || err.message;

        console.error("❌ Ошибка отправки телеметрии:", msg);

        // Если сервер говорит "устройство недействительно" — отключаемся
        if (status === 403 || msg.includes("Не удалось добавить телеметрию")) {
          console.log("🚫 Устройство более не авторизовано. Закрываем WebSocket.");
          isRunning = false;
          clearInterval(intervalId);
          ws.close();
          process.exit(0);
        }
      }
    }, 1000);
  }
});

ws.on("close", () => {
  console.log("❌ WebSocket отключён");
  isRunning = false;
  clearInterval(intervalId);
});

ws.on("error", (err) => {
  console.error("🚨 Ошибка WebSocket:", err.message);
});
