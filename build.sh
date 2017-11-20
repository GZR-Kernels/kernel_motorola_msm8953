#!/bin/bash

### Prema Chand Alugu (premaca@gmail.com)
### Shivam Desai (shivamdesaixda@gmail.com)
### A custom build script to build zImage & DTB(Anykernel2 method)

set -e

DATE_POSTFIX=$(date +"%Y%m%d")

## Copy this script inside the kernel directory
KERNEL_DIR=$PWD
CROSS_COMPILE_PREFIX=arm-linux-androidkernel-
KERNEL_TOOLCHAIN=$HOME/Android/Val/prebuilts/gcc/linux-x86/arm/arm-linux-androideabi-4.9/bin/$CROSS_COMPILE_PREFIX
KERNEL_DEFCONFIG=sanders_defconfig
DTBTOOL=$KERNEL_DIR/Dtbtool/
JOBS=8
ANY_KERNEL2_DIR=$KERNEL_DIR/AnyKernel2/
FINAL_KERNEL_ZIP=Drunk_Optimus_Sanders-$DATE_POSTFIX.zip

while [[ $# -gt 0 ]]
do
key="$1"

case $key in
    clean)
    CLEAN_BUILD=YES
    #shift # past argument
    ;;
    *)
            # unknown option
    ;;
esac
shift # past argument or value
done

# Clean build optional
if [ "$CLEAN_BUILD" == 'YES' ]
then echo;
    echo "**** Cleaning ****"
    make clean && make mrproper
fi

# The MAIN Part
echo "**** Setting Toolchain ****"
export CROSS_COMPILE=$KERNEL_TOOLCHAIN
export ARCH=arm
echo "**** Kernel defconfig is set to $KERNEL_DEFCONFIG ****"
make $KERNEL_DEFCONFIG
make -j$JOBS

# Time for dtb
echo "**** Generating DT.IMG ****"
$DTBTOOL/dtbToolCM -2 -o $KERNEL_DIR/arch/arm/boot/dtb -s 2048 -p $KERNEL_DIR/scripts/dtc/ $KERNEL_DIR/arch/arm/boot/dts/qcom/

echo "**** Verify zImage & dtb ****"
ls $KERNEL_DIR/arch/arm/boot/zImage
ls $KERNEL_DIR/arch/arm/boot/dtb

#Anykernel 2 time!!
echo "**** Verifying Anyernel2 Directory ****"
ls $ANY_KERNEL2_DIR
echo "**** Removing leftovers ****"
rm -rf $ANY_KERNEL2_DIR/dtb
rm -rf $ANY_KERNEL2_DIR/zImage
rm -rf $ANY_KERNEL2_DIR/$FINAL_KERNEL_ZIP

echo "**** Copying zImage ****"
cp $KERNEL_DIR/arch/arm/boot/zImage $ANY_KERNEL2_DIR/
echo "**** Copying dtb ****"
cp $KERNEL_DIR/arch/arm/boot/dtb $ANY_KERNEL2_DIR/

echo "**** Time to zip up! ****"
cd $ANY_KERNEL2_DIR/
zip -r9 $FINAL_KERNEL_ZIP * -x README $FINAL_KERNEL_ZIP

echo;
echo "**** Good Bye!! ****"
echo;
cd $KERNEL_DIR
rm -rf arch/arm/boot/dtb
rm -rf AnyKernel2/zImage
rm -rf AnyKernel2/dtb

echo "#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#"
echo "##                                                      ##"
echo "##     KERNEL BUILD IS SUCCESSFUL                       ##"
echo "##                                                      ##"
echo "##     Flash this $ANY_KERNEL2_DIR/$FINAL_KERNEL_ZIP    ##"
echo "##                                                      ##"
echo "#@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@#"
