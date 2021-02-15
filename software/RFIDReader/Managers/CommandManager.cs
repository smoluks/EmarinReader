using RFIDReader.Entity;
using System;
using System.Threading;
using System.Threading.Tasks;

namespace RFIDReader.Managers
{
    public class CommandManager : IDisposable
    {
        ComPortManager _comPortManager;

        public CommandManager(string portname)
        {
            try
            {
                _comPortManager = new ComPortManager(portname);
            }
            catch (ApplicationException ex)
            {
                Dispose();
                throw new ApplicationException("Device doesn't respond");
            }
            catch (Exception ex)
            {
                Dispose();
                throw new ApplicationException(ex.Message.Trim());
            }
        }

        public void Dispose()
        {
            _comPortManager?.Dispose();
        }

        public async Task PingAsync(CancellationToken cancellationToken)
        {
            await _comPortManager.SendAsync(new byte[0], 1000, cancellationToken);
        }

        public async Task Login4305Async(CancellationToken cancellationToken)
        {
            await _comPortManager.SendAsync(new byte[] { 0x21, 0x00, 0x00, 0x00, 0x00 }, 3000, cancellationToken);
        }

        public async Task Write4305Async(byte address, byte[] data, CancellationToken cancellationToken)
        {
            await _comPortManager.SendAsync(new byte[] { 0x22, address, data[0], data[1], data[2], data[3] }, 3000, cancellationToken);
        }

        public async Task<Emarin> ReadEmarinAsync(CancellationToken cancellationToken)
        {
            int count = 0;
            int repeatCount = 0;
            int delay = 200;

            var data = new byte[8];
            bool first = true;

            do
            {
                await Task.Delay(delay);
                var newData = await _comPortManager.SendAsync(new byte[2] { 0x20, 0x40 }, 10000, cancellationToken);

                if (newData[0] == 0xFF && (newData[1] & 0x01) == 0x01)
                {
                    if (!first) {
                        if (CompareArray(data, newData))
                        {
                            repeatCount++;
                        }
                        else
                        {
                            delay += 100;
                        }
                    }

                    data = newData;
                    first = false;
                }
                
                count++;
            }
            while (count < 20 && repeatCount < 3);
            if (count >= 20)
            {
                throw new ApplicationException("Bad connection");
            }

            return new Emarin(data);
        }

        private bool CompareArray(byte[] data, byte[] newData)
        {
            if (data.Length != newData.Length)
                return false;

            for (int i = 0; i < data.Length; i++)
            {
                if (data[i] != newData[i])
                    return false;
            }

            return true;
        }
    }
}
