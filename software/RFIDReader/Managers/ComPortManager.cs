using RFIDReader.Extensions;
using System;
using System.Collections.Generic;
using System.IO.Ports;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;

namespace RFIDReader.Managers
{
    public class ComPortManager : IDisposable
    {
        const int BAUDRATE = 500000;
        const Parity PARITY = Parity.Odd;
        const int IO_TIMEOUT = 500;

        readonly SerialPort _serialPort;
        readonly Queue<byte> receiveQueue = new Queue<byte>();
        private TaskCompletionSource<byte[]> tcs;

        internal string Port { get; private set; }

        internal ComPortManager(string portname)
        {
            Port = portname;

            _serialPort = new SerialPort
            {
                PortName = portname,
                BaudRate = BAUDRATE,
                Parity = PARITY,
                ReadTimeout = IO_TIMEOUT,
                WriteTimeout = IO_TIMEOUT
            };

            _serialPort.Open();
            _serialPort.DataReceived += DataReceivedHandler;

            if (_serialPort.BaudRate != BAUDRATE)
            {
                _serialPort.Close();
                throw new ApplicationException($"BaudRate {BAUDRATE} doesn't support by this COM port");
            }
        }

        public void Dispose()
        {
            if (_serialPort == null)
                return;

            if (_serialPort.IsOpen)
            {
                //close may froze
                Task.WhenAny(Task.Run(() => _serialPort.Close()), Task.Delay(3000)).Wait();
            }

            _serialPort.Dispose();
        }

        ~ComPortManager()
        {
            _serialPort?.Close();
        }

        internal static IEnumerable<string> GetAvaliableComPorts()
        {
            return SerialPort.GetPortNames();
        }

        internal async Task<byte[]> SendAsync(byte[] buffer, int timeout, CancellationToken token)
        {
            var array = new byte[buffer.Count() + 3];
            array[0] = 0xAB;
            array[1] = (byte)buffer.Count();
            buffer.CopyTo(array, 2);
            array[buffer.Count() + 2] = CRCManager.GetCrc(array, 0, buffer.Count() + 2);

            LogManager.WriteData($"{_serialPort.PortName} Send: ", array);

            //send packet
            _serialPort.Write(array, 0, buffer.Count() + 3);

            var task = WaitAnswerAsync();

            //receive packet
            if (await Task.WhenAny(task, Task.Delay(timeout), token.AsTask()) == task)
            {
                var result = await task;
                tcs = null;
                return result;
            }
            else
            {
                throw new ApplicationException("Packet timeout");
            }
        }

        private Task<byte[]> WaitAnswerAsync()
        {
            tcs = new TaskCompletionSource<byte[]>();
            return tcs.Task;
        }

        private void DataReceivedHandler(object sender, SerialDataReceivedEventArgs e)
        {
            SerialPort sp = (SerialPort)sender;
            var count = sp.BytesToRead;
            var data = new byte[count];
            var readed = sp.Read(data, 0, count);

            LogManager.WriteData($"{_serialPort.PortName} Receive: ", data);

            //push to queue
            for (int i = 0; i < readed; i++)
                receiveQueue.Enqueue(data[i]);

            //try to restore packet from queue
            ProcessQueue();
        }

        private void ProcessQueue()
        {
            while (receiveQueue.Count > 2)
            {
                //get marker
                var marker = receiveQueue.ElementAt(0);
                if (marker != 0xAB)
                {
                    receiveQueue.Dequeue();
                    continue;
                }

                //get length
                var length = receiveQueue.ElementAt(1);
                if (receiveQueue.Count < length + 3)
                    return; //wait fully packet

                //process packet
                receiveQueue.Dequeue();
                receiveQueue.Dequeue();
                byte crc = CRCManager.GetAdditiveCrc(length, 0x8F);

                var data = new byte[length];
                for (int i = 0; i < length; i++)
                    data[i] = receiveQueue.Dequeue();

                var receivedcrc = receiveQueue.Dequeue();
                if (receivedcrc != CRCManager.GetCrc(data, 0, -1, crc))
                {
                    LogManager.WriteText("bad crc");
                    return;
                }

                if (tcs != null)
                {
                    tcs.SetResult(data);
                }
                else
                {
                    //custom packets
                }
            }
        }
    }
}
