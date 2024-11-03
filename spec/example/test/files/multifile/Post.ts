// START AUTOGEN

import { Comment } from "./Comment";
import { User } from "./User";

type Model = {
  id: number;
  type: "posts";
  description: string;
  relationships: {
    user: User;
    comments: Array<Comment>;
    participants: Array<User>;
  };
};

// END AUTOGEN

type Post = Model;

export { type Post };
