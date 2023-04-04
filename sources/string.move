module 0xCAFE::StringUtil {
    use 0x1::vector;

    struct String has copy, drop, store {
        bytes: vector<u8>,
    }

    public fun new(bytes: vector<u8>): String {
        String {
            bytes,
        }
    }

    public fun bytes(s: &String): vector<u8> {
        s.bytes
    }

    // returns the length of this string, in bytes.
    public fun length(s: &String): u64 {
        vector::length(&s.bytes)
    }

    // appends `r` to `s`
    public fun append(s: &mut String, r: String) {
        vector::append<u8>(&mut s.bytes, r.bytes);
    }

    // convert a integer to String
    public fun from_num(i: u64): String {
        let s = new(vector::empty<u8>());
        while(i!=0){
            let m:u8 = ((i%256) as u8);
            vector::push_back<u8>(&mut s.bytes, m);
            i = i>>8;
        };
        vector::reverse<u8>(&mut s.bytes);
        s
    }
}
