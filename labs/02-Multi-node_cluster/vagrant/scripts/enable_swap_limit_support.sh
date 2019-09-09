#sudo echo "GRUB_CMDLINE_LINUX='cgroup_enable=memory swapaccount=1'" >> /etc/default/grub
sudo perl -p -i -e 's/GRUB_CMDLINE_LINUX_DEFAULT.*/GRUB_CMDLINE_LINUX_DEFAULT="cgroup_enable=memory swapaccount=1 console=tty1 console=ttyS0"/g' /etc/default/grub.d/50-cloudimg-settings.cfg
sudo update-grub