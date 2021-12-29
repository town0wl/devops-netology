### ДЗ 7.5

1.
```
package main

import "fmt"

func normalize(foots float64) float64 {
	return 0.3048 * foots
}

func main() {
	fmt.Print("Enter how many foots: ")
	var input float64
	p, _ := fmt.Scanf("%f", &input)
	if p == 1 {
		fmt.Printf("%.4f", normalize(input))
	} else {
		fmt.Println("Some meters")
	}
}
```

main_test.go:
```
package main

import "testing"

func TestMain(t *testing.T) {
	v := normalize(0.00)
	if v != 0 {
		t.Error("Expected 0, got ", v)
	}
	v = normalize(10000.00)
	if v != 3048 {
		t.Error("Expected 3048, got ", v)
	}
	v = normalize(-100.00)
	if v != -30.48 {
		t.Error("Expected -30.48, got ", v)
	}
}
```

2.
```
package main

import "fmt"

func read_array() ([]int, int) {
	fmt.Printf("Enter array length: ")
	var n int
	p, _ := fmt.Scanf("%d\n", &n)
	if p != 1 || n < 1 {
		return nil, 3
	}
	arr := make([]int, n)
	for i := 0; i < n; i++ {
		fmt.Printf("Enter next element: ")
		p, _ = fmt.Scanf("%d\n", &arr[i])
		if p != 1 {
			return nil, 4
		}
	}
	return arr, 0
}

func min(array []int) int {
    min := array[0]
    for _, value := range array {
        if min > value {
            min = value
        }
    }
    return min
}

func main() {
	x, status := read_array()
	if status != 0 {
		fmt.Println("Incorrect value, default array will be used")
		x = []int{48,96,86,68,57,82,63,70,37,34,83,27,19,97,9,17,}
	}
	fmt.Println(x)
	fmt.Println(min(x))
}
```

main_test.go:
```
package main

import "testing"

func TestMain(t *testing.T) {
	v := min([]int{0,1,2})
	if v != 0 {
		t.Error("Expected 0, got ", v)
	}
	v = min([]int{0,1,2,-999})
	if v != -999 {
		t.Error("Expected -999, got ", v)
	}
}
```

3.
```
package main

import "fmt"

func main() {
	for i := 1; i < 100; i++ {
		if i%3 == 0 {
			fmt.Printf("%d ", i)
		}
	}
}
```
