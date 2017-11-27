namespace ValaScript {
    public int hexval(string c)
    {
        string ref = "0123456789abcdef";
        return ref.index_of(c);

    }
    string convert_to_decimal_string  (string hex) {
        //convert the string to lowercase
        string hexdown = hex.down();
        //get the length of the hex string
        int hexlen = hex.length;
        int64 ret_val = 0;
        string chr;
        int chr_int;
        int multiplier;

        //loop through the string
        for (int i = 0; i < hexlen ; i++) {
        //get the string chars from right to left
        int inv = (hexlen-1)-i;
        chr = hexdown[inv:inv+1];
        chr_int = hexval(chr);

        //how are we going to multiply the current characters value?
        multiplier = 1;
        for(int j = 0 ; j < i ; j++) {
        multiplier *= 16;
        }
        ret_val += chr_int * multiplier;
        }
        return ret_val.to_string ();
    }
}
