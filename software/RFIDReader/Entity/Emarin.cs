using BitStreams;
using System;

namespace RFIDReader.Entity
{
    public class Emarin
    {
        public Bit[] Header { get; }
        public Bit[,] Data { get; } = new Bit[10,4];
        public Bit[] RowParity { get; } = new Bit[10];
        public Bit[] ColumnParity { get; } = new Bit[4];
        public Bit StopBit  { get; }
         
        public Emarin(byte[] raw)
        {            
            if(raw.Length != 8)
            {
                throw new ApplicationException("bad length");
            }

            var bitstream = new BitStream(raw, false);

            Header = bitstream.ReadBits(9);

            for(int i = 0; i < 10; i++)
            {
                for (int j = 0; j < 4; j++)
                {
                    Data[i, j] = bitstream.ReadBit();
                }

                RowParity[i] = bitstream.ReadBit();
            }

            ColumnParity = bitstream.ReadBits(4);

            StopBit = bitstream.ReadBit();
        }

        public Bit GetRowParity(byte rowNumber)
        {
            return GetParityInternal(Data[rowNumber, 0], Data[rowNumber, 1], Data[rowNumber, 2], Data[rowNumber, 3]);
        }

        public Bit GetColumnParity(byte columnNumber)
        {
            return GetParityInternal(
                Data[0, columnNumber],
                Data[1, columnNumber],
                Data[2, columnNumber],
                Data[3, columnNumber],
                Data[4, columnNumber],
                Data[5, columnNumber],
                Data[6, columnNumber],
                Data[7, columnNumber],
                Data[8, columnNumber],
                Data[9, columnNumber]);
        }

        private Bit GetParityInternal(params Bit[] bits)
        {
            var result = new Bit();

            foreach(var bit in bits)
            {
                result ^= bit;
            }

            return result;
        }
    }
}
