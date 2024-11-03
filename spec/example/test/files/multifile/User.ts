// START AUTOGEN

import { UserRole } from "./shared";
import { Comment } from "./Comment";
import { Post } from "./Post";

type Model = {
  id: number;
  type: "users";
  name: string;
  role: UserRole;
  relationships: {
    comments: Array<Comment>;
    posts: Array<Post>;
  };
};

// END AUTOGEN

type User = Model;

export { type User };
