public class TeamShip{
    String name;
    float x, y, angle, size;
    int points;
    boolean dead;

    public TeamShip(String name){
        this.name = name;
        this.x = width/2;
        this.y = height/2;
        this.dead = false;
        this.angle = 0;
        points = 0;
        this.size = 20;
    }

    public String getName(){
        return name;
    }

    public void setDead(boolean b){
        dead = b;
    }

    public void setPoints(int p){
        points = p;
    }

    public int getPoints(){
        return points;
    }

    public void setPos(float x, float y, float angle){
        this.x = x;
        this.y = y;
        this.angle = angle;
    }

    public void show(){
        if (!dead){
            pushMatrix();

            noFill();
            stroke(127, 242, 255);
            strokeWeight(3);

            translate(x, y);
            rotate(angle);
            triangle(-size, size, 0, -size - 5, size, size);
            fill(255);
            textSize(20);

            popMatrix();
            textAlign(CENTER);
            text(name, x, y + 30 + size);
        }
    }
}
