#include "firmware.h"

int main(void)
{
    print_str("Booting...\n");
	print_str("\n");
	print_str("  ____  _          ____         ____\n");
	print_str(" |  _ \\(_) ___ ___/ ___|  ___  / ___|\n");
	print_str(" | |_) | |/ __/ _ \\___ \\ / _ \\| |\n");
	print_str(" |  __/| | (_| (_) |__) | (_) | |___\n");
	print_str(" |_|   |_|\\___\\___/____/ \\___/ \\____|\n");
	print_str("\n");
    print_str("Boots successfully!\n");

	set_timer(10000000);

    while (1) {
		;
	}
	return 0;
}
