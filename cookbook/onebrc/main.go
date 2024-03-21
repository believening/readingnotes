package main

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"sort"
	"strconv"
	"strings"
)

// cal min/max/mean
type result struct {
	min, max, total float32
	cnt             float32
}

func (r result) String() string {
	return fmt.Sprintf("%.1f/%.1f/%.1f", r.min, r.total/r.cnt, r.max)
}

var cities []string
var store map[string]*result = map[string]*result{}

func main() {
	filePath := os.Args[1]
	f, err := os.Open(filePath)
	if err != nil {
		log.Fatal(err)
	}
	reader := bufio.NewReader(f)
	for {
		l, _, err := reader.ReadLine()
		if err != nil {
			break
		}
		n, t := parseOneline(string(l))
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
	f.Close()
	sort.StringSlice(cities).Sort()
	out, _ := os.OpenFile(os.Args[2], os.O_CREATE|os.O_RDWR, 0644)
	out.WriteString("{")
	for idx, n := range cities {
		out.WriteString(n)
		out.WriteString("=")
		out.WriteString(store[n].String())
		if idx != len(cities)-1 {
			out.WriteString(", ")
		}
	}
	out.WriteString("}\n")
	out.Close()
}

func parseOneline(s string) (string, float32) {
	seq := strings.Index(s, ";")
	name := s[:seq]
	strTemperature := s[seq+1:]
	temperature, _ := strconv.ParseFloat(strTemperature, 32)
	return name, float32(temperature)
}
