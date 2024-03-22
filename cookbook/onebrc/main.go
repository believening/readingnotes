// 50000000, base 8.5
// 1 replace all strconv.ParseFloat to parseFloat  5.4 -> 4.6
// 2 replace all string([]byte) to [64]byte        4.6 -> 4.4
// 3 replace all parseFloat to parseInt            4.4 -> 4.0
package main

import (
	"bufio"
	"bytes"
	"fmt"
	"log"
	"math"
	"os"
	"runtime"
	"runtime/pprof"
	"sort"
	"sync"
)

// cal min/max/mean
type result struct {
	min, max, total int
	cnt             int
}

func (r result) String() string {
	return fmt.Sprintf("%.1f/%.1f/%.1f", float32(r.min)/10.0, float32(r.total)/10.0/float32(r.cnt), float32(r.max)/10.0)
}

type cityName struct {
	start   int
	content [64]byte
}

func (c cityName) String() string {
	return string(c.content[c.start:])
}

var cities []cityName
var store map[cityName]*result = map[cityName]*result{}

func main() {
	pproff := "./cpu.pprof"
	runner := run
	// pproff := "./1pnc.cpu.pprof"
	// runner := run1PnC

	cpupprof, _ := os.OpenFile(pproff, os.O_CREATE|os.O_RDWR|os.O_TRUNC, 0644)
	defer cpupprof.Close()
	pprof.StartCPUProfile(cpupprof)

	runner(os.Args[1])
	print(os.Args[2])

	pprof.StopCPUProfile()
	cpupprof.Sync()
}

func run(filePath string) {
	f, err := os.Open(filePath)
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()

	// fi, err := f.Stat()
	// if err != nil {
	// 	log.Fatal(err)
	// }
	// data, err := syscall.Mmap(int(f.Fd()), 0, int(fi.Size()), syscall.PROT_READ, syscall.MAP_SHARED)
	// if err != nil {
	// 	log.Fatal(err)
	// }
	// defer syscall.Munmap(data)
	// bytesReader := bytes.NewReader(data)
	reader := bufio.NewReader(f)
	for {
		l, _, err := reader.ReadLine()
		if err != nil {
			break
		}
		n, t := parseOneline(l)
		got, ok := store[n]
		if !ok {
			cities = append(cities, n)
			got = &result{
				min:   999,
				total: 0,
				max:   -999,
				cnt:   0,
			}
		}
		got.cnt++
		if t < got.min {
			got.min = t
		}
		if t > got.max {
			got.max = t
		}
		got.total += t
		store[n] = got
	}
}

func run1PnC(filePath string) {
	f, err := os.Open(filePath)
	if err != nil {
		log.Fatal(err)
	}
	defer f.Close()
	ch := make(chan []byte, 10)
	// go func() {
	// 	for {
	// 		time.Sleep(500 * time.Millisecond)
	// 		fmt.Println(len(ch))
	// 	}
	// }()

	go func() {
		reader := bufio.NewReader(f)
		for {
			l, _, err := reader.ReadLine()
			if err != nil {
				break
			}
			ch <- l
		}
		close(ch)
	}()
	var wg sync.WaitGroup
	runnerCnt := runtime.NumCPU()
	storeCh := make(chan map[cityName]*result, runnerCnt)
	for i := 0; i < runnerCnt; i++ {
		wg.Add(1)
		go func() {
			defer wg.Done()
			var localStore map[cityName]*result = map[cityName]*result{}
			for l := range ch {
				n, t := parseOneline(l)
				got, ok := localStore[n]
				if !ok {
					got = &result{
						min:   999,
						total: 0,
						max:   -999,
						cnt:   0,
					}
				}
				got.cnt++
				if t < got.min {
					got.min = t
				}
				if t > got.max {
					got.max = t
				}
				got.total += t
				localStore[n] = got
			}
			storeCh <- localStore
		}()
	}
	wg.Wait()
	close(storeCh)
	for localStore := range storeCh {
		for n, r := range localStore {
			got, ok := store[n]
			if !ok {
				cities = append(cities, n)
				got = &result{
					min:   999,
					total: 0,
					max:   -999,
					cnt:   0,
				}
			}
			got.cnt += r.cnt
			if r.min < got.min {
				got.min = r.min
			}
			if r.max > got.max {
				got.max = r.max
			}
			got.total += r.total
			store[n] = got
		}
	}
}

func print(outFile string) {
	if outFile == "" {
		outFile = "/dev/stdout"
	}
	sort.Slice(cities, func(i, j int) bool {
		return string(cities[i].content[cities[i].start:]) < string(cities[j].content[cities[j].start:])
	})
	out, _ := os.OpenFile(os.Args[2], os.O_CREATE|os.O_RDWR, 0644)
	out.WriteString("{")
	for idx, n := range cities {
		out.WriteString(n.String())
		out.WriteString("=")
		out.WriteString(store[n].String())
		if idx != len(cities)-1 {
			out.WriteString(", ")
		}
	}
	out.WriteString("}\n")
	out.Close()
}

func parseOneline(s []byte) (cityName, int) {
	var seq int
	seq = bytes.IndexByte(s, ';')

	// temperature, _ := strconv.ParseFloat(string(s[seq+1:]), 32)
	// return s[:seq], float32(temperature)
	city := cityName{
		start: 64 - seq,
	}
	copy(city.content[city.start:], s[:seq])
	return city, parseInt(s[seq+1:])
}

func parseOnelineFloat(s []byte) (cityName, float32) {
	var seq int
	seq = bytes.IndexByte(s, ';')

	// temperature, _ := strconv.ParseFloat(string(s[seq+1:]), 32)
	// return s[:seq], float32(temperature)
	city := cityName{
		start: 64 - seq,
	}
	copy(city.content[city.start:], s[:seq])
	return city, parseFloat(s[seq+1:])
}

func parseInt(s []byte) int {
	result := 0
	isNegative := false

	if s[0] == '-' {
		isNegative = true
		s = s[1:]
	}

	for _, c := range s {
		if c >= '0' && c <= '9' {
			result = result*10 + int(c-'0')
		}
	}

	if isNegative {
		result = -result
	}

	return result
}

func parseFloat(s []byte) float32 {
	result := 0.0
	dotPos := -1
	isNegative := false

	if s[0] == '-' {
		isNegative = true
		s = s[1:]
	}

	for i, c := range s {
		if c >= '0' && c <= '9' {
			result = result*10 + float64(c-'0')
		} else if c == '.' {
			dotPos = i
		}
	}

	if dotPos != -1 {
		result = result / math.Pow(10, float64(len(s)-dotPos-1))
	}

	if isNegative {
		result = -result
	}

	return float32(result)
}
