module 0xCAFE::MapUtil {
    use 0x1::vector;
    use 0x1::option;

    struct Element<T, U> has copy, drop, store {
        key: T,
        value: U,
    }

    struct Map<T, U> has copy, drop, store {
        list: vector<Element<T, U>>,
    }

    public fun new<T, U>(): Map<T, U> {
        Map {
            list: vector::empty(),
        }
    }

    public fun length<T, U>(m: &Map<T, U>): u64 {
        // return the length of the items
        vector::length(&m.list)
    }

    fun find_index<T, U>(m: &Map<T, U>, key: &T): option::Option<u64> {
        let length = length(m);
        if (length == 0) {
            return option::none()
        };

        let index = 0;
        while (index < length) {
            let potential_key = &vector::borrow(&m.list, index).key;
            if (potential_key == key) {
                return option::some(index)
            };
            index = index + 1;
        };

        option::none()
    }

    public fun contains<T, U>(m: &Map<T, U>, key: &T): bool {
        let exist = find_index(m, key);
        option::is_some(&exist)
    }

    public fun keys<T: copy, U>(m: &Map<T, U>): vector<T> {
        let keys = vector::empty<T>();
        // return the copy of the keys
        let length = length(m);
        if (length == 0) {
            return keys
        };

        let index = 0;
        while (index < length) {
            let potential_key = &vector::borrow(&m.list, index).key;
            vector::push_back<T>(&mut keys, *potential_key);
            index = index + 1;
        };
        keys
    }

    public fun add<T, U>(m: &mut Map<T, U>, key: T, value: U) {
        assert!(!contains(m, &key), 100);

        // add the key-value to the map
        vector::push_back<Element<T, U>>(&mut m.list, Element<T, U>{key, value});
    }

    public fun remove<T:drop, U>(m: &mut Map<T, U>, key: &T): (T, U) {
        let maybe_index = find_index(m, key);
        assert!(option::is_some(&maybe_index), 102);

        let index = option::extract(&mut maybe_index);

        // remove and return the key-value from the map
        let Element<T, U>{key:nkey, value:nvalue} = vector::remove<Element<T, U>>(&mut m.list, index);

        (nkey, nvalue)
    }
}
