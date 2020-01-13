
package app;

import java.util.Vector;

public class TestResources {
    public static void main(String[] args) {
        Runtime rt = Runtime.getRuntime();
        Vector v = new Vector();

        while (rt.freeMemory() > 5210000) {
            byte b[] = new byte[1024000];
            v.add(b);
            rt = Runtime.getRuntime();
            System.out.println("Used memory: " + (Runtime.getRuntime().totalMemory() - Runtime.getRuntime().freeMemory()) / 1024 / 1024 + " MB");
        }

        System.out.println("Max Processors: " + Runtime.getRuntime().availableProcessors());
        System.out.println("Max Memory: " + Runtime.getRuntime().maxMemory() / 1024 / 1024);
    }
}