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

                PingAsync(CancellationToken.None).GetAwaiter().GetResult();
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
                var newData = await _comPortManager.SendAsync(new byte[1] { 0x20 }, 10000, cancellationToken);

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
