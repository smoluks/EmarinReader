using System.Linq;

namespace RFIDReader.Managers
{
    public static class CRCManager
    {
        public static byte GetAdditiveCrc(byte data, byte oldcrc)
        {
            for (byte bitCounter = 0; bitCounter < 8; bitCounter++)
            {
                if (((oldcrc ^ data) & 0x01) != 0)
                {
                    oldcrc = (byte)((oldcrc >> 1) ^ 0x8C);
                }
                else
                {
                    oldcrc >>= 1;
                }
                data >>= 1;
            }
            return oldcrc;
        }

        public static byte GetCrc(byte[] data, int offset = 0, int count = -1, byte startvalue = 0)
        {
            byte crc = startvalue;
            if (count < 0)
                count = data.Count();

            for (int index = offset; index < count; index++)
            {
                var currentByte = data[index];
                for (byte bitCounter = 0; bitCounter < 8; bitCounter++)
                {
                    if (((crc ^ currentByte) & 0x01) != 0)
                    {
                        crc = (byte)((crc >> 1) ^ 0x8C);
                    }
                    else
                    {
                        crc >>= 1;
                    }
                    currentByte >>= 1;
                }
            }
            return crc;
        }
    }
}
