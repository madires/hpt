# Netmail routes
# формат:
#  route <как> <куда> <для кого> [для кого ...]
# 	как - direct, hold итд.
#	куда - адрес нашего линка
#	для кого - шаблон адреса назначения
#
#route direct 2:9999/99 2:9999/99.*
#route direct 2:9999/99 2:9999/*
route direct 2:5020/9999 *
