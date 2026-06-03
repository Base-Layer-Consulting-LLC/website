export type NavLink = {
    href: string;
    label: string;
    enabled?: boolean;
    external?: boolean;
    blank?: boolean;
    order?: number;
    dropdownHover?: boolean;
    children?: NavLink[];
}

export const navLinks: NavLink[] = [
    { href: "/", label: "Home", enabled: false, order: 0 },
    // Example dropdown menu. Set `enabled: true` to show it on the page.
    // {
    //     href: "#",
    //     label: "Test Dropdown",
    //     enabled: false,
    //     order: 60,
    //     dropdownHover: true,
    //     children: [
    //         { href: "#", label: "Child 1", enabled: true, order: 0 },
    //         { href: "#", label: "Child 2", enabled: true, order: 0 }
    //     ]
    // }
]