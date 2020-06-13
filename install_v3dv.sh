#!/bin/sh -e

echo 1/12 Update
sudo apt update

echo 2/12 Upgrade
sudo apt full-upgrade -y

echo 3/12 Install pre-requisites
sudo apt install libxcb-randr0-dev libxrandr-dev \
        libxcb-xinerama0-dev libxinerama-dev libxcursor-dev \
        libxcb-cursor-dev libxkbcommon-dev xutils-dev \
        xutils-dev libpthread-stubs0-dev libpciaccess-dev \
        libffi-dev x11proto-xext-dev libxcb1-dev libxcb-*dev \
        bison flex libssl-dev libgnutls28-dev x11proto-dri2-dev \
        x11proto-dri3-dev libx11-dev libxcb-glx0-dev \
        libx11-xcb-dev libxext-dev libxdamage-dev libxfixes-dev \
        libva-dev x11proto-randr-dev x11proto-present-dev \
        libclc-dev libelf-dev git build-essential mesa-utils \
        libvulkan-dev ninja-build libvulkan1 \
        libdrm-dev libxshmfence-dev libxxf86vm-dev libassimp-dev cmake

echo 4/12 Install meson
pip3 install meson

echo 5/12 Install mako
pip3 install mako

echo 6/12 Get v3dv

cd ~
git clone --single-branch --branch wip/igalia/v3dv https://gitlab.freedesktop.org/apinheiro/mesa.git mesa

echo 7/12 Build v3dv
cd mesa
meson --prefix /home/pi/local-install --libdir lib -Dplatforms=x11,drm -Dvulkan-drivers=broadcom -Ddri-drivers= -Dgallium-drivers=v3d,kmsro,vc4 -Dbuildtype=debug _build
ninja -C _build
ninja -C _build install
 
echo 8/12 Set environment variable
if [ "$(uname -m)" = "aarch64" ]; then
    export VK_ICD_FILENAMES=/home/pi/local-install/share/vulkan/icd.d/broadcom_icd.aarch64.json
else
    export VK_ICD_FILENAMES=/home/pi/local-install/share/vulkan/icd.d/broadcom_icd.armv7l.json
fi

echo 9/12 Get demos
cd ~
git clone --recursive https://github.com/SaschaWillems/Vulkan.git
cd Vulkan

echo 10/12 Get assets
python3 download_assets.py

echo 11/12 Build demos
if [ ! -d build ]; then
    mkdir build
fi
#mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Debug  ..
make

echo 12/12 Run gears demo
cd ~/Vulkan/build/bin/
./gears

