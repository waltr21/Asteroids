public class TeamShip{
    String name;
    float x, y, angle, size;
    boolean dead;

    public TeamShip(String name){
        this.name = name;
        this.x = width/2;
        this.y = height/2;
        this.dead = false;
        this.angle = 0;
        this.size = 20;

    }

    public void show(){
        pushMatrix();

        noFill();
        stroke(255);
        strokeWeight(3);

        translate(x, y);
        rotate(angle);
        triangle(-size, size, 0, -size - 5, size, size);
        fill(255);
        text(name, x, y + size + 10);

        popMatrix();
    }
}
