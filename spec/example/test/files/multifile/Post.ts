// START AUTOGEN

import type { Comment } from "./Comment";
import type { User } from "./User";

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
