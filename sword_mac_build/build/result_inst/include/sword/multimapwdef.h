#ifndef MULTIMAPWDEF
#define MULTIMAPWDEF

#include <map>

SWORD_NAMESPACE_START

// multmap that still lets you use [] to reference FIRST
// entry of a key if multiples exist
template <class Key, class T, class Compare>
class multimapwithdefault : public std::multimap<Key, T, Compare> {
public:
	typedef std::pair<const Key, T> value_type;
	T& getWithDefault(const Key& k, const T& defaultValue) {
		if (find(k) == this->end()) {
			insert(value_type(k, defaultValue));
		}
		return (*(find(k))).second;
	}

	T& operator[](const Key& k) {
		if (find(k) == this->end()) {
			insert(value_type(k, T()));
		}
		return (*(find(k))).second;
	}
	bool has(const Key& k, const T &val) const {
		typename std::multimap<Key, T, Compare>::const_iterator start = lower_bound(k);
		typename std::multimap<Key, T, Compare>::const_iterator end = upper_bound(k);
		for (; start!=end; start++) {
			if (start->second == val)
				return true;
		}
		return false;
	}
};

SWORD_NAMESPACE_END
#endif
