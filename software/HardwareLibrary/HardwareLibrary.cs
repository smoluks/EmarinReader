namespace HardwareLibrary
{
    public class HardwareLibrary
    {
        public enum EventType
        {
            ReadSuccess,
            WriteSuccess
        };

        public delegate void IButtonHandler(EventType type);

        public delegate void CyfralHandler(EventType type);

        public delegate void MetacomHandler(EventType type);

        public delegate void EmMarinHandler(EventType type);


    }
}
