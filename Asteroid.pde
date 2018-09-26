public class Asteroid{
    float x, y, size;
    int level;
    PVector velocity;

    public Asteroid(float x, float y, int level){
        this.x = x;
        this.y = y;
        this.size = 30 * level;
        this.level = level;
        velocity = PVector.fromAngle(random(-PI, PI));
        velocity.mult((4-level) * 0.5);
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

    public void explode(){
        if (level > 1){
            int numChildren = 2;
            asteroids.remove(this);
            for (int i = 0; i < numChildren; i++){
                asteroids.add(new Asteroid(x, y, level - 1));
            }
        }
        else{
            asteroids.remove(this);
        }
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

    public float getX(){
        return x;
    }

    public float getY(){
        return y;
    }

    public float getSize(){
        return size;
    }
}
