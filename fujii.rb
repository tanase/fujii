# -*- coding: utf-8 -*-

losses = gets.to_i
ratings = gets.split().map(&:to_i)

cands = [1650, 1700, 1750, 1800, 1850, 1900, 1950, 2000, 2050, 2100]

def expected(ra, rb)
  return 1.0 / (1 + 10 ** ((rb - ra)/400.0))
end

# raの人がちょうどloss敗する確率
def calc_sub(memo, ra, ratings, pos, loss)
  if pos >= ratings.length
    return loss == 0 ? 1 : 0
  end
  idx = pos * ratings.length + loss
  if memo[idx] >= 0
    return memo[idx]
  end
  e = expected(ra, ratings[pos])
  p = e * calc_sub(memo, ra, ratings, pos + 1, loss)
  if loss > 0
    p += (1-e) * calc_sub(memo, ra, ratings, pos + 1, loss-1)
  end
  return memo[idx] = p
end

# raの人がloss敗以下する確率
def calc(memo, ra, ratings, loss)
  p = 0
  for l in 0 .. loss
    p += calc_sub(memo, ra, ratings, 0, l)
  end
  return p
end

for loss in 0 .. losses do
  puts "LOSS:#{loss}\n"
  cands.each do |cand|
    memo = Array.new(ratings.length * ratings.length, -1)
    printf("%d => %4.1f%%\n", cand, 100*calc(memo, cand, ratings, loss))
  end

  # ちょうどN%
  [1, 2.5, 5, 10, 20, 50, 90, 95, 97.5].each do |thres|
    lo = 1000.0
    hi = 2400.0
    while hi - lo > 1e-10
      memo = Array.new(ratings.length * ratings.length, -1)
      mid = (hi + lo) / 2
      p = calc(memo, mid, ratings, loss)
      if p * 100 > thres
        hi = mid
      else
        lo = mid
      end
    end
    printf("%5.1f%%:%.1f\n", thres, mid)
  end
end
