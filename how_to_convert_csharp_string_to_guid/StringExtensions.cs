namespace how_to_convert_csharp_string_to_guid
{
    public static class StringExtensions
    {
        private const ulong KnuthInitValue = 3074457345618258791ul;
        private const ulong KnuthMultiValue = 3074457345618258799ul;

        // Based on https://stackoverflow.com/questions/9545619/a-fast-hash-function-for-string-in-c-sharp
        public static Guid ToGuid(this string str)
        {
            // Double Knuth hash
            ulong hashedValueEven = KnuthInitValue;
            ulong hashedValueOdd = KnuthInitValue;
            for (int i = 0; i < str.Length; i++)
            {
                if (i % 2 == 0)
                {
                    hashedValueEven += str[i];
                    hashedValueEven *= KnuthMultiValue;
                }
                else
                {
                    hashedValueOdd += str[i];
                    hashedValueOdd *= KnuthMultiValue;
                }
            }
            return new Guid(new byte[] {
                (byte)(0xff & hashedValueEven),
                (byte)(0xff & hashedValueEven >> 8),
                (byte)(0xff & hashedValueEven >> 16),
                (byte)(0xff & hashedValueEven >> 24),
                (byte)(0xff & hashedValueEven >> 32),
                (byte)(0xff & hashedValueEven >> 40),
                (byte)(0xff & hashedValueEven >> 48),
                (byte)(0xff & hashedValueEven >> 56),
                (byte)(0xff & hashedValueOdd),
                (byte)(0xff & hashedValueOdd >> 8),
                (byte)(0xff & hashedValueOdd >> 16),
                (byte)(0xff & hashedValueOdd >> 24),
                (byte)(0xff & hashedValueOdd >> 32),
                (byte)(0xff & hashedValueOdd >> 40),
                (byte)(0xff & hashedValueOdd >> 48),
                (byte)(0xff & hashedValueOdd >> 56),
            });
        }
    }
}