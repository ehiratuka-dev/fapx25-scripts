# FAPx#25 Support Scripts

Support scripts for the project **FAPx#25**, focused on data handling, manipulation, standardization, and automated report generation in a Termux environment.

## Features

- Easily install and execute the `fap25` command  
- Modular script structure with additional sub-scripts  
- Optimized for Termux environments

## Requirements

- [Termux](https://f-droid.org/packages/com.termux/)  
- `dpkg-deb` utility (comes with Termux's `dpkg` package)

## Installation

### 1. Clone the repository

```bash
git clone https://github.com/ehiratuka-dev/fapx25-scripts.git
cd fapx25-scripts
```

### 2. Build the `.deb` package

```bash
dpkg-deb --build fap25
```

This will generate a `fap25.deb` file in the current directory.

### 3. Install the package

```bash
dpkg -i fap25.deb
```

### 4. Run the main script

```bash
fap25
```

## Directory structure

The main script and its dependencies are organized as follows:

```text
fap25/
├── DEBIAN/
│   └── control
└── data/
    └── data/
        └── com.termux/
            └── files/
                └── usr/
                    ├── bin/
                    │   └── fap25
                    └── share/
                        └── fap25/
                            └── scripts/
                                └── [your supporting scripts]
```

## Customization

You can add more supporting scripts under `fap25/data/data/com.termux/files/usr/share/fap25/scripts/` and call them from within the main `fap25` script.

## License

[MIT](LICENSE)
