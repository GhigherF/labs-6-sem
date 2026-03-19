package P03_02

import "fmt"

type Stats struct {
	PostCounter int
	GetCounter  int
}

func (s *Stats) PlusGet()  { s.GetCounter++ }
func (s *Stats) PlusPost() { s.PostCounter++ }
func (s Stats) GenStr() string {
	return fmt.Sprint("Get-request count = ", s.GetCounter, "    Post-request count = ", s.PostCounter)
}
