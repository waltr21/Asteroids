public class Asteroid{
    float x, y, size;
    PVector velocity;

    public Asteroid(float x, float y, float level){
        this.x = x;
        this.y = y;
        this.size = 20 * level;
        velocity = PVector.fromAngle(random(-PI, PI));
        velocity.mult(6-level);
    }


    /**
     * Bound the Asteroid to stay inside of the screen.
     */
    public void bound(){
        if (x + size < 0){
            x = width + size/2;
        }
        else if (x - size > width){
            x = 0 - size/2;
        }

        if (y + size < 0){
            y = height + size/2;
        }
        else if (y - size > height){
            y = 0 - size/2;
        }
    }

    public void travel(){
        x += velocity.x;
        y += velocity.y;
    }

    public void show(){
        pushMatrix();
        travel();
        bound();
        ellipseMode(CENTER);
        translate(x, y);
        ellipse(0, 0, size, size);
        popMatrix();
    }
}
